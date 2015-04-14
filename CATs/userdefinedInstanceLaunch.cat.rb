name 'userdefinedInstanceLaunch'
rs_ca_ver 20131202
short_description 'CAT demonstrating how to launch a certain number of instances based on user input'

# Basic Server Resource
resource 'server1_m1small', type: 'server' do
  name 'server1_m1small [Base ServerTemplate for Linux (v13.5.11-LTS)]'
  cloud 'EC2 us-west-2'
  instance_type 'm1.small'
  multi_cloud_image find('RightImage_CentOS_6.6_x64_v13.5_LTS', revision: 14)
  ssh_key 'Bryan'
  network "EC2-Classic"
  security_groups 'default'
  server_template find('rs_tag + Base ServerTemplate for Linux (v13.5.11-LTS)', revision: 0)
  inputs do {
  } end
end

## Here's the primary logic for the userfedinedInstanceLaunch
# Setup the User Input -- $number
parameter "number" do
  label "Number of instances to launch"
  type "number"
  min_value 1
  max_value 100
end

# Override the default 'launch' behavior with our own method `launch_concurrent`

operation "launch" do
  definition "launch_concurrent"
end

# Define the launch_concurrent method
define launch_concurrent(@server1_m1small, $number) do
  # cache the server resource configuration
  $thing = to_object(@server1_m1small)

  # create the loop counter $array
  call sys_get_array_of_size($number) retrieve $array

  # concurrently provision the servers
  concurrent foreach $item in $array do
    provision(@server1_m1small)
  end

end

# sys_get_array_of_size is a helper method which sets up a loop counter
define sys_get_array_of_size($size) return $array do
  $qty = 1
  $qty_ary = []
  while $qty <= to_n($size) do
    $qty_ary << $qty
    $qty = $qty + 1
  end

  $array = $qty_ary
end
