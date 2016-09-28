<% import rust as lang %>\
pub mod reader;
pub mod writer;
pub mod util;
pub mod object;
pub mod update;

use ::packet::enums::*;

use std::collections::HashMap;
<% packet = packets.get("ServerPacket") %>\
#[derive(Debug)]
pub enum ${packet.name}
{
    % for case in packet.fields:
    ${case.name}
    {
        % for field in case.fields:
        % if not loop.first:

        % endif
        % for line in util.format_comment(field.comment, indent="/// ", width=73):
        ${line}
        % endfor
        ${field.name}: ${lang.rust_type(field.type)},
        % endfor
    },

    % endfor
}