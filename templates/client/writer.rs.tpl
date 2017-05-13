<% import rust %>\
${rust.header()}

use std::io;
use std::io::Result;

use ::packet::enums::frametype;
use ::packet::client::ClientPacket;
use ::wire::ArtemisEncoder;
use ::wire::CanEncode;
use ::wire::trace;

impl<'a> CanEncode for &'a ClientPacket
{
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()>
    {
        match self
        {
        % for name, info in sorted(rust.generate_packet_ids("ClientParser").items()):
            &${name} {
            % for fld in rust.get_packet(name).fields:
                ${rust.ref_struct_field(fld)},
            % endfor
            } => Ok({
                trace::packet_write("${name}");
                wtr.write::<u32>(frametype::${info[1]})?;
            % if info[2]:
                wtr.write::<u32>(${info[2]})?;
            % endif
            % for fld in rust.get_packet(name).fields:
                write_field!("packet", "${fld.name}", &${fld.name}, ${rust.write_struct_field(fld.name, fld.type, True)});
            % endfor
            % for x in range(rust.get_packet_padding(rust.get_packet(name), info[1])):
                % if loop.first:
                // padding
                % endif
                wtr.write::<u32>(0)?;
            % endfor
            }),
        % endfor
            _ => Err(io::Error::new(io::ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}
