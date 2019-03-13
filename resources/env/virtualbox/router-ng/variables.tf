# Flight Staging Account - IAM Resources - Variables

variable "name" {
  description = <<-EOF
    Resource name.
  EOF
}

variable "memory" {
  description = <<-EOF
    Amount of RAM.
  EOF
}

variable "service" {
  description = <<-EOF
    Service to be hosted.
  EOF
}
variable "url" {
  description = <<-EOF
    URL of VM Image.
  EOF
}
variable "image" {
  description = <<-EOF
    Image for VM.
  EOF
}

variable "imagedir" {
  description = <<-EOF
    Directory for image files.
  EOF
}

variable "interface" {
  description = <<-EOF
    Primary interface to bridge to.
  EOF
}

variable "interface2" {
  description = <<-EOF
    Secondary interface to bridge to.
  EOF
}

variable "cpus" {
  description = <<-EOF
    Amount of CPU's to set for VM.
  EOF
}

variable "count" {
  description = <<-EOF
    Number of instances of this resource to launch.
  EOF
}
