<% import rust %>\
${rust.header()}
use std::io::Result;

use ::wire::trace;
use ::packet::structs::*;

% for struct in structs.without("Update"):
impl CanDecode for ${struct.name} {
    fn read(rdr: &mut ArtemisDecoder) -> Result<Self> {
        trace::struct_read("${struct.name}");
        Ok(${struct.name} {
            % for field in struct.fields:
            ${field.name}: parse_field!("struct", "${field.name}", rdr.read()?),
            % endfor
        })
    }
}

% endfor
