<% import rust %>\
${rust.header()}

use std::io::Result;
use num::ToPrimitive;

use ::packet::enums::frametype;
use ::packet::client::ClientPacket;
use ::stream::FrameWriter;
use ::wire::ArtemisEncoder;
use ::wire::traits::CanEncode;

pub struct ClientPacketWriter
{
}

impl ClientPacketWriter
{
    pub fn new() -> Self { ClientPacketWriter { } }
}

<%
def visit(parser, res):
    for field in parser.fields:
        if field.type.name == "struct":
            res[field.type[0].name] = (field.type, field.name, None, None)
        elif field.type.name == "parser":
            prs = parsers.get(field.type[0].name)
            for fld in prs.fields:
                res[fld.type[0].name] = (fld.type, field.name, fld.name, prs.arg)

packet_ids = dict()
parser = parsers.get("ClientParser")
visit(parser, packet_ids)

def get_padding(name):
    packet = rust.get_packet(name)
    if info[1] == "valueInt":
        return 1 - len(packet.fields)
    elif info[1] == "valueFourInts":
        return 4 - len(packet.fields)
    else:
        return 0
%>
impl FrameWriter for ClientPacketWriter
{
    type Frame = ClientPacket;
    fn write_frame(&mut self, frame: &Self::Frame) -> Result<Vec<u8>>
    {
        let mut wtr = ArtemisEncoder::new();
        match frame
        {
        % for name, info in sorted(packet_ids.items()):
            &${name} {
            % for fld in rust.get_packet(name).fields:
            % if rust.is_ref_type(fld.type):
                ref ${fld.name},
            % else:
                ${fld.name},
            % endif
            % endfor
            } => {
                wtr.write_u32(frametype::${info[1]})?;
            % if info[2]:
                wtr.write_u32(${info[2]})?;
            % endif
            % for fld in rust.get_packet(name).fields:
                ${rust.write_field(name, fld.name, fld.type)};
            % endfor
            % for x in range(get_padding(name)):
                % if loop.first:
                // padding
                % endif
                wtr.write_u32(0)?;
            % endfor
            },

        % endfor
        }
        Ok(wtr.into_inner())
    }
}
