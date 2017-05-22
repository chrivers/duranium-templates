<% import rust %>\
${rust.header()}

use std::io::{Result, Error, ErrorKind};

use wire::trace;
use wire::types::*;

use packet::enums::frametype;
use packet::client::ClientPacket;
use packet::client;

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

impl<'a> CanEncode for &'a ClientPacket {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        match *self {
        % for name, info in sorted(rust.generate_packet_ids("ClientParser").items()):
            ${name}(ref pkt) => write_packet!("${name}", frametype::${info[1]}, ${info[2]}, wtr, pkt),
        % endfor
            _ => Err(Error::new(ErrorKind::InvalidData, "unsupported protocol version")),
        }
    }
}

% for lname, info in sorted(rust.generate_packet_ids("ClientParser").items()):
<% name = lname.split("::", 1)[-1] %>\
impl<'a> CanEncode for &'a client::${name} {
    fn write(self, mut wtr: &mut ArtemisEncoder) -> Result<()> {
        % for fld in rust.get_packet(lname).fields:
        write_field!("packet", "${fld.name}", self.${fld.name}, ${rust.write_struct_field("self.%s" % fld.name, fld.type)});
        % endfor
        % for x in range(rust.get_packet_padding(rust.get_packet(lname), info[1])):
        wtr.write::<u32>(0)?; // padding
        % endfor
        Ok(())
    }
}

% endfor
