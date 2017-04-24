<% import rust %>\
${rust.header()}
use std::io;

use ::packet::structs::*;
use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;

% for struct in structs:
<% if struct.name == "Update": continue %>\

impl CanEncode for ${struct.name}
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<(), io::Error>
    {
        % for field in struct.fields:
        ${rust.write_field(None, "self.%s" % field.name, field.type)};
        % endfor
        Ok(())
    }
}

% endfor