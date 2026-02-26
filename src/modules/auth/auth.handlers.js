const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const { z } = require("zod");

const env = require("../../config/env");
const prisma = require("../../lib/prisma");
const { isMailerConfigured, sendPasswordResetOtpEmail } = require("../../services/mailer");

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

const logoutSchema = z.object({
  refreshToken: z.string().min(1).optional(),
});

const forgotPasswordSchema = z.object({
  email: z.string().email(),
});

const verifyOtpSchema = z.object({
  email: z.string().email(),
  otp: z.string().trim().regex(/^\d{6}$/),
});

const resetPasswordSchema = z.object({
  resetToken: z.string().min(1),
  newPassword: z
    .string()
    .min(8)
    .regex(/[A-Z]/, "Password must include an uppercase letter")
    .regex(/[a-z]/, "Password must include a lowercase letter")
    .regex(/[0-9]/, "Password must include a number")
    .regex(/[^A-Za-z0-9]/, "Password must include a special character"),
});

const changePasswordSchema = z.object({
  currentPassword: z.string().min(6),
  newPassword: z
    .string()
    .min(8)
    .regex(/[A-Z]/, "Password must include an uppercase letter")
    .regex(/[a-z]/, "Password must include a lowercase letter")
    .regex(/[0-9]/, "Password must include a number")
    .regex(/[^A-Za-z0-9]/, "Password must include a special character"),
});

const passwordResetSecret = env.PASSWORD_RESET_SECRET || env.JWT_REFRESH_SECRET;

function toSafeUser(user) {
  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    role: user.role,
    schoolId: user.schoolId,
    branchId: user.branchId,
    isActive: user.isActive,
  };
}

function hashToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function tokenExpiryFromJwt(token, fallbackDays = 7) {
  const decoded = jwt.decode(token);
  if (decoded && typeof decoded === "object" && decoded.exp) {
    return new Date(decoded.exp * 1000);
  }
  return new Date(Date.now() + fallbackDays * 24 * 60 * 60 * 1000);
}

function buildJwtPayload(user) {
  return {
    sub: user.id,
    email: user.email,
    role: user.role,
    schoolId: user.schoolId,
    branchId: user.branchId,
  };
}

function issueAccessToken(payload) {
  return jwt.sign(
    { ...payload, tokenType: "access" },
    env.JWT_ACCESS_SECRET,
    { expiresIn: env.ACCESS_TOKEN_EXPIRES_IN }
  );
}

function issueRefreshToken(payload) {
  return jwt.sign(
    {
      ...payload,
      tokenType: "refresh",
      jti: crypto.randomUUID(),
    },
    env.JWT_REFRESH_SECRET,
    { expiresIn: env.REFRESH_TOKEN_EXPIRES_IN }
  );
}

function issuePasswordResetToken(payload) {
  return jwt.sign(
    {
      ...payload,
      tokenType: "password_reset",
      jti: crypto.randomUUID(),
    },
    passwordResetSecret,
    { expiresIn: env.PASSWORD_RESET_TOKEN_EXPIRES_IN }
  );
}

function unauthorized(res, message = "Invalid credentials") {
  return res.status(401).json({
    success: false,
    error: { code: "UNAUTHORIZED", message },
  });
}

function logAuthSecurityEvent(req, reason) {
  const ip = req.ip || req.headers["x-forwarded-for"] || "unknown";
  console.warn(`[auth] ${reason} path=${req.originalUrl} ip=${ip}`);
}

function invalidOtp(res, message = "Invalid or expired OTP") {
  return res.status(400).json({
    success: false,
    error: { code: "INVALID_OTP", message },
  });
}

function invalidResetToken(res, message = "Invalid or expired reset token") {
  return res.status(401).json({
    success: false,
    error: { code: "INVALID_RESET_TOKEN", message },
  });
}

async function login(req, res, next) {
  try {
    const { email, password } = loginSchema.parse(req.body);
    const normalizedEmail = email.toLowerCase();

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (!user || !user.isActive) {
      return unauthorized(res, "Invalid email or password");
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return unauthorized(res, "Invalid email or password");
    }

    const payload = buildJwtPayload(user);
    const accessToken = issueAccessToken(payload);
    const refreshToken = issueRefreshToken(payload);

    await prisma.$transaction([
      prisma.user.update({
        where: { id: user.id },
        data: { lastLoginAt: new Date() },
      }),
      prisma.refreshToken.create({
        data: {
          userId: user.id,
          tokenHash: hashToken(refreshToken),
          expiresAt: tokenExpiryFromJwt(refreshToken),
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        accessToken,
        refreshToken,
        user: toSafeUser(user),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function refresh(req, res, next) {
  try {
    const { refreshToken } = refreshSchema.parse(req.body);

    let decoded;
    try {
      decoded = jwt.verify(refreshToken, env.JWT_REFRESH_SECRET, {
        algorithms: ["HS256"],
      });
    } catch (error) {
      logAuthSecurityEvent(req, "invalid_refresh_token_signature");
      return unauthorized(res, "Invalid or expired refresh token");
    }

    if (
      !decoded ||
      typeof decoded !== "object" ||
      decoded.tokenType !== "refresh" ||
      typeof decoded.sub !== "string"
    ) {
      logAuthSecurityEvent(req, "invalid_refresh_token_payload");
      return unauthorized(res, "Invalid refresh token");
    }

    const storedToken = await prisma.refreshToken.findUnique({
      where: { tokenHash: hashToken(refreshToken) },
      include: { user: true },
    });

    if (!storedToken || storedToken.revokedAt) {
      logAuthSecurityEvent(req, "refresh_token_not_found_or_revoked");
      return unauthorized(res, "Refresh token is revoked or invalid");
    }

    if (storedToken.expiresAt < new Date()) {
      logAuthSecurityEvent(req, "refresh_token_expired");
      return unauthorized(res, "Refresh token is expired");
    }

    if (!storedToken.user || !storedToken.user.isActive) {
      logAuthSecurityEvent(req, "refresh_user_inactive");
      return unauthorized(res, "User is inactive");
    }

    const payload = buildJwtPayload(storedToken.user);
    const nextAccessToken = issueAccessToken(payload);
    const nextRefreshToken = issueRefreshToken(payload);

    await prisma.$transaction([
      prisma.refreshToken.update({
        where: { id: storedToken.id },
        data: { revokedAt: new Date() },
      }),
      prisma.refreshToken.create({
        data: {
          userId: storedToken.user.id,
          tokenHash: hashToken(nextRefreshToken),
          expiresAt: tokenExpiryFromJwt(nextRefreshToken),
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        accessToken: nextAccessToken,
        refreshToken: nextRefreshToken,
        user: toSafeUser(storedToken.user),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function logout(req, res, next) {
  try {
    const { refreshToken } = logoutSchema.parse(req.body || {});

    if (!refreshToken) {
      return res.status(200).json({
        success: true,
        data: { message: "Logged out" },
      });
    }

    await prisma.refreshToken.updateMany({
      where: {
        tokenHash: hashToken(refreshToken),
        revokedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });

    return res.status(200).json({
      success: true,
      data: { message: "Logged out" },
    });
  } catch (error) {
    return next(error);
  }
}

async function me(req, res, next) {
  try {
    const userId = req.user?.sub;
    if (!userId) {
      return unauthorized(res, "Invalid access token payload");
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.isActive) {
      return res.status(404).json({
        success: false,
        error: { code: "USER_NOT_FOUND", message: "User not found" },
      });
    }

    return res.status(200).json({
      success: true,
      data: { user: toSafeUser(user) },
    });
  } catch (error) {
    return next(error);
  }
}

async function forgotPassword(req, res, next) {
  try {
    const { email } = forgotPasswordSchema.parse(req.body);
    const normalizedEmail = email.toLowerCase();

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
      select: { id: true, email: true, isActive: true },
    });

    if (!user || !user.isActive) {
      return res.status(200).json({
        success: true,
        data: {
          message:
            "If your account exists, a verification code has been generated",
        },
      });
    }

    const otp = crypto.randomInt(100000, 1000000).toString();
    const otpHash = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(
      Date.now() + env.PASSWORD_RESET_OTP_EXPIRES_MINUTES * 60 * 1000
    );

    await prisma.$transaction([
      prisma.passwordResetOtp.updateMany({
        where: {
          email: normalizedEmail,
          usedAt: null,
        },
        data: {
          usedAt: new Date(),
        },
      }),
      prisma.passwordResetOtp.create({
        data: {
          email: normalizedEmail,
          otpHash,
          expiresAt,
        },
      }),
    ]);

    if (isMailerConfigured()) {
      await sendPasswordResetOtpEmail({
        to: normalizedEmail,
        otp,
        expiresInMinutes: env.PASSWORD_RESET_OTP_EXPIRES_MINUTES,
      });
    } else if (env.NODE_ENV === "production") {
      throw new Error("Email service is not configured in production");
    }

    return res.status(200).json({
      success: true,
      data: {
        message:
          "If your account exists, a verification code has been generated",
        debugOtp: env.NODE_ENV === "production" ? undefined : otp,
        otpExpiresAt: expiresAt.toISOString(),
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function verifyOtp(req, res, next) {
  try {
    const { email, otp } = verifyOtpSchema.parse(req.body);
    const normalizedEmail = email.toLowerCase();

    const record = await prisma.passwordResetOtp.findFirst({
      where: {
        email: normalizedEmail,
        usedAt: null,
      },
      orderBy: { createdAt: "desc" },
    });

    if (!record || record.expiresAt <= new Date()) {
      return invalidOtp(res);
    }

    const isOtpValid = await bcrypt.compare(otp, record.otpHash);
    if (!isOtpValid) {
      return invalidOtp(res);
    }

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
      select: { id: true, email: true, isActive: true },
    });

    if (!user || !user.isActive) {
      return invalidOtp(res);
    }

    await prisma.passwordResetOtp.update({
      where: { id: record.id },
      data: { usedAt: new Date() },
    });

    const resetToken = issuePasswordResetToken({
      sub: user.id,
      email: user.email,
    });

    return res.status(200).json({
      success: true,
      data: {
        resetToken,
        expiresIn: env.PASSWORD_RESET_TOKEN_EXPIRES_IN,
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function resetPassword(req, res, next) {
  try {
    const { resetToken, newPassword } = resetPasswordSchema.parse(req.body);

    let decoded;
    try {
      decoded = jwt.verify(resetToken, passwordResetSecret, {
        algorithms: ["HS256"],
      });
    } catch (error) {
      logAuthSecurityEvent(req, "invalid_password_reset_token");
      return invalidResetToken(res);
    }

    if (
      !decoded ||
      typeof decoded !== "object" ||
      decoded.tokenType !== "password_reset" ||
      typeof decoded.sub !== "string" ||
      typeof decoded.email !== "string"
    ) {
      return invalidResetToken(res);
    }

    const user = await prisma.user.findUnique({
      where: { id: decoded.sub },
      select: { id: true, email: true, isActive: true },
    });

    if (!user || !user.isActive || user.email !== decoded.email) {
      return invalidResetToken(res);
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);

    await prisma.$transaction([
      prisma.user.update({
        where: { id: user.id },
        data: { passwordHash },
      }),
      prisma.refreshToken.updateMany({
        where: {
          userId: user.id,
          revokedAt: null,
        },
        data: {
          revokedAt: new Date(),
        },
      }),
      prisma.passwordResetOtp.updateMany({
        where: {
          email: user.email,
          usedAt: null,
        },
        data: {
          usedAt: new Date(),
        },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        message: "Password reset successful. Please login again.",
      },
    });
  } catch (error) {
    return next(error);
  }
}

async function changePassword(req, res, next) {
  try {
    const userId = req.user?.sub;
    if (!userId) {
      return unauthorized(res, "Invalid access token payload");
    }

    const payload = changePasswordSchema.parse(req.body);

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, isActive: true, passwordHash: true },
    });

    if (!user || !user.isActive) {
      return unauthorized(res, "User is inactive");
    }

    const isCurrentPasswordValid = await bcrypt.compare(
      payload.currentPassword,
      user.passwordHash
    );
    if (!isCurrentPasswordValid) {
      return unauthorized(res, "Current password is incorrect");
    }

    const isSamePassword = await bcrypt.compare(payload.newPassword, user.passwordHash);
    if (isSamePassword) {
      return res.status(400).json({
        success: false,
        error: {
          code: "BAD_REQUEST",
          message: "New password must be different from current password",
        },
      });
    }

    const newPasswordHash = await bcrypt.hash(payload.newPassword, 10);

    await prisma.$transaction([
      prisma.user.update({
        where: { id: user.id },
        data: { passwordHash: newPasswordHash },
      }),
      prisma.refreshToken.updateMany({
        where: {
          userId: user.id,
          revokedAt: null,
        },
        data: { revokedAt: new Date() },
      }),
    ]);

    return res.status(200).json({
      success: true,
      data: {
        message: "Password changed successfully. Please login again.",
      },
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  login,
  refresh,
  logout,
  me,
  forgotPassword,
  verifyOtp,
  resetPassword,
  changePassword,
};
