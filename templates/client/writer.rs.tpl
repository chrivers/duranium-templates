<% import rust %>\
${rust.header()}

use packet::prelude::*;
use packet::enums::frametype;
use super::ClientPacket;

macro_rules! write_packet {
    ($name:expr, $major:expr, None,        $wtr:ident, $pkt:ident) => {{
        trace::packet_write($name);
        $wtr.write::<u32>($major)?;
        $wtr.write($pkt)
    }};
    ($name:expr, $major:expr, $minor:expr, $wtr:ident, $pkt:ident) => {{
        trace::packet_write($name);
        $wtr.write::<u32>($major)?;
        $wtr.write::<u32>($minor)?;
        $wtr.write($pkt)
    }};
}

% for packet in _client:
<% parser = packet.field("@parser").type.link %>\
<% prefix = parser.field("@type").type.link.name.lower() %>\
impl<'a> CanEncode for &'a ${packet.name} {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        match *self {
            % for name, info in rust.generate_packet_ids(parser.name):
            ${packet.name}::${name}(ref pkt) => write_packet!("${packet.name}::${name}", ${prefix}::${info[1]}, ${info[2]}, wtr, pkt),
            % endfor
            _ => Err(Error::new(ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

% for case in packet:
impl<'a> CanEncode for &'a super::${case.name} {
    fn write(self, mut _wtr: &mut ArtemisEncoder) -> Result<()> {
        % for fld in case.fields:
        ${rust.write_struct_field("packet", fld)};
        % endfor
        Ok(())
    }
}

% endfor
% endfor
