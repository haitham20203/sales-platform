terraform {
  backend "gcs" {
    bucket = "globant-gdp-tfstate"
    prefix = "terraform/state"
  }
}
