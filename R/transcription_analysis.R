# Transcription analysis

library(recount3)


proj_info <- subset(
  human_projects,
  project == 'SRP040070' & project_type == "data_sources"
)
