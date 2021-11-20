# deployment functions and script

Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv("R_CONFIG_ACTIVE"=
             "sqldb")
Sys.setenv("R_CONFIG_ACTIVE" = "shinyapps")
Sys.setenv("R_CONFIG_ACTIVE" = "local")



deploy_add_table("accounts_user")
deploy_add_table(proposed_table = "accounts_firebase")
deploy_add_table(proposed_table = "experiments")
