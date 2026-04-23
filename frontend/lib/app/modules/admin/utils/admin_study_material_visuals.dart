import 'package:erp_frontend/app/modules/admin/models/admin_study_material_models.dart';
import 'package:flutter/material.dart';

Color adminStudyMaterialColor(AdminStudyMaterialCategory category) {
  switch (category) {
    case AdminStudyMaterialCategory.notes:
      return Colors.teal;
    case AdminStudyMaterialCategory.videos:
      return Colors.orange;
    case AdminStudyMaterialCategory.pdfs:
      return Colors.redAccent;
    case AdminStudyMaterialCategory.resources:
      return Colors.indigo;
  }
}

IconData adminStudyMaterialIcon(AdminStudyMaterialCategory category) {
  switch (category) {
    case AdminStudyMaterialCategory.notes:
      return Icons.sticky_note_2_rounded;
    case AdminStudyMaterialCategory.videos:
      return Icons.play_circle_fill_rounded;
    case AdminStudyMaterialCategory.pdfs:
      return Icons.picture_as_pdf_rounded;
    case AdminStudyMaterialCategory.resources:
      return Icons.link_rounded;
  }
}

String adminStudyMaterialDescription(AdminStudyMaterialCategory category) {
  switch (category) {
    case AdminStudyMaterialCategory.notes:
      return 'Share classroom notes, slides, and written study references.';
    case AdminStudyMaterialCategory.videos:
      return 'Publish recorded lessons, explainers, and video walkthrough links.';
    case AdminStudyMaterialCategory.pdfs:
      return 'Upload PDF handouts, question banks, and printable study packs.';
    case AdminStudyMaterialCategory.resources:
      return 'Curate learning links, reference websites, and extra resources.';
  }
}

String adminStudyMaterialHelperText(AdminStudyMaterialCategory category) {
  switch (category) {
    case AdminStudyMaterialCategory.notes:
      return 'Paste a hosted note, slide, image, or document link for students.';
    case AdminStudyMaterialCategory.videos:
      return 'Paste a YouTube, Vimeo, Drive, or direct video link.';
    case AdminStudyMaterialCategory.pdfs:
      return 'Paste the direct or hosted PDF link you want to publish.';
    case AdminStudyMaterialCategory.resources:
      return 'Paste a website, article, or hosted learning resource link.';
  }
}

String adminStudyMaterialEmptyLabel(AdminStudyMaterialCategory category) {
  switch (category) {
    case AdminStudyMaterialCategory.notes:
      return 'No notes published yet.';
    case AdminStudyMaterialCategory.videos:
      return 'No videos published yet.';
    case AdminStudyMaterialCategory.pdfs:
      return 'No PDFs published yet.';
    case AdminStudyMaterialCategory.resources:
      return 'No learning resources published yet.';
  }
}

