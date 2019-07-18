/* This will use the output variables to update the firewall configuration template
   to reflect the proper parameters for the IP Address.
*/

data "template_file" "check_fw_import_gp" {
  template = "${file("templates/check_fw_import_gp.sh")}"

  vars {
    fw1_mgmt_ip = "${aws_eip.ManagementElasticIP.public_ip}"
  }
}

resource "local_file" "check_fw_import_gp" {
  content  = "${data.template_file.check_fw_import_gp.rendered}"
  filename = "templates/check_fw_import_gp.sh"
}

/* Check that Firewall 1 is up and push the rendered configs */
resource "null_resource" "check_fw_import_gp" {
  depends_on = ["local_file.check_fw_import_gp"]

  triggers {
    key = "${aws_instance.FWInstance.id}"
  }

  provisioner "local-exec" {
    command = "templates/check_fw_import_gp.sh"
  }
}
