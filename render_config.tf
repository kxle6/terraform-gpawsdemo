/* This will use the output variables to update the firewall configuration template
   to reflect the proper parameters for the IP Address.
*/

data "template_file" "fw1_config_push" {
  template = "${file("templates/fw1_config_push")}"

  vars {
    fw1_mgmt_ip = "${aws_eip.ManagementElasticIP.public_ip}"
  }
}

resource "local_file" "fw1_config_push" {
  content  = "${data.template_file.fw1_config_push.rendered}"
  filename = "templates/fw1_config_push.sh"
}

/* Check that Firewall 1 is up and push the rendered configs */
resource "null_resource" "fw1_check_and_push" {
  depends_on = ["local_file.fw1_config_push"]

  triggers {
    key = "${aws_instance.FWInstance.id}"
  }

  provisioner "local-exec" {
    command = "templates/fw1_config_push.sh"
  }
}
