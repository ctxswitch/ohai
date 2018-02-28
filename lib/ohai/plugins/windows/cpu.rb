#
# Author:: Doug MacEachern <dougm@vmware.com>
# Copyright:: Copyright (c) 2010 VMware, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:CPU) do
  provides "cpu"

  collect_data(:windows) do
    require "wmi-lite/wmi"

    cpu Mash.new
    cores = 0
    logical_processors = 0

    wmi = WmiLite::Wmi.new
    processors = wmi.instances_of("Win32_Processor")

    processors.each_with_index do |processor, index|
      current_cpu = index.to_s
      cpu[current_cpu] = Mash.new

      cpu[current_cpu]["cores"] = processor["numberofcores"]
      cores += processor["numberofcores"]

      logical_processors += processor["numberoflogicalprocessors"]
      cpu[current_cpu]["vendor_id"] = processor["manufacturer"]
      cpu[current_cpu]["family"] = processor["family"].to_s
      cpu[current_cpu]["model"] = processor["revision"].to_s
      cpu[current_cpu]["stepping"] = if processor["stepping"].nil?
                                       processor["description"].match(/Stepping\s+(\d+)/)[1]
                                     else
                                       processor["stepping"]
                                     end
      cpu[current_cpu]["physical_id"] = processor["deviceid"]
      cpu[current_cpu]["model_name"] = processor["name"]
      cpu[current_cpu]["description"] = processor["description"]
      cpu[current_cpu]["mhz"] = processor["maxclockspeed"].to_s
      cpu[current_cpu]["cache_size"] = "#{processor['l2cachesize']} KB"
    end

    cpu[:total] = logical_processors
    cpu[:cores] = cores
    cpu[:real] =  processors.length
  end
end
