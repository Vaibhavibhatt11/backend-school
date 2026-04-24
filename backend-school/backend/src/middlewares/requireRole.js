function requireRole(allowedRoles = []) {
  return (req, res, next) => {
    if (!req.user?.role) {
      return res.status(401).json({
        success: false,
        error: { code: "UNAUTHORIZED", message: "User context not found" },
      });
    }

    const isAllowed = allowedRoles.includes(req.user.role);
    if (!isAllowed) {
      return res.status(403).json({
        success: false,
        error: { code: "FORBIDDEN", message: "Access denied for this role" },
      });
    }

    return next();
  };
}

module.exports = requireRole;

