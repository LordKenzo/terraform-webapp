locals {
  project              = "${var.prefix}-${var.env_short}-${var.location_short}"
  is_prod              = var.env_short == "p" ? true : false
}
