import 'package:erp_frontend/app/modules/staff/models/staff_study_material_models.dart';
import 'package:flutter/material.dart';

Color staffStudyMaterialColor(StaffStudyMaterialCategory category) {
  switch (category) {
    case StaffStudyMaterialCategory.notes:
      return Colors.teal;
    case StaffStudyMaterialCategory.videos:
      return Colors.orange;
    case StaffStudyMaterialCategory.pdfs:
      return Colors.redAccent;
    case StaffStudyMaterialCategory.resources:
      return Colors.indigo;
  }
}

IconData staffStudyMaterialIcon(StaffStudyMaterialCategory category) {
  switch (category) {
    case StaffStudyMaterialCategory.notes:
      return Icons.sticky_note_2_rounded;
    case StaffStudyMaterialCategory.videos:
      return Icons.play_circle_fill_rounded;
    case StaffStudyMaterialCategory.pdfs:
      return Icons.picture_as_pdf_rounded;
    case StaffStudyMaterialCategory.resources:
      return Icons.link_rounded;
  }
}

String staffStudyMaterialDescription(StaffStudyMaterialCategory category) {
  switch (category) {
    case StaffStudyMaterialCategory.notes:
      return 'Share classroom notes, slides, and written study references.';
    case StaffStudyMaterialCategory.videos:
      return 'Publish recorded lessons, explainers, and video walkthrough links.';
    case StaffStudyMaterialCategory.pdfs:
      return 'Upload PDF handouts, question banks, and printable study packs.';
    case StaffStudyMaterialCategory.resources:
      return 'Curate learning links, reference websites, and extra resources.';
  }
}

String staffStudyMaterialHelperText(StaffStudyMaterialCategory category) {
  switch (category) {
    case StaffStudyMaterialCategory.notes:
      return 'Paste a hosted note, slide, image, or document link for students.';
    case StaffStudyMaterialCategory.videos:
      return 'Paste a YouTube, Vimeo, Drive, or direct video link.';
    case StaffStudyMaterialCategory.pdfs:
      return 'Paste the direct or hosted PDF link you want to publish.';
    case StaffStudyMaterialCategory.resources:
      return 'Paste a website, article, or hosted learning resource link.';
  }
}

String staffStudyMaterialEmptyLabel(StaffStudyMaterialCategory category) {
  switch (category) {
    case StaffStudyMaterialCategory.notes:
      return 'No notes published yet.';
    case StaffStudyMaterialCategory.videos:
      return 'No videos published yet.';
    case StaffStudyMaterialCategory.pdfs:
      return 'No PDFs published yet.';
    case StaffStudyMaterialCategory.resources:
      return 'No learning resources published yet.';
  }
}
