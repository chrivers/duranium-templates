<% import rust %>\
${rust.header()}
#![allow(unused_variables)]
use std::io;

use ::packet::enums::*;
use ::packet::update::*;
use ::wire::ArtemisDecoder;
use ::stream::FrameReadAttempt;

% for object in objects:

#[derive(Debug)]
pub struct ${object.name} {
    object_id: u32,
% for field in object.fields:
    % if object.name == "PlayerShipUpgrade":
    ${"{:30}".format(field.name+":")} ${rust.declare_type(field.type)}, // ${"".join(field.comment)}
    % else:
    % if not loop.first:

    % endif
    % for line in util.format_comment(field.comment, indent="// ", width=74):
    ${line}
    % endfor
    pub ${field.name}: ${rust.declare_type(field.type)},
    % endif
% endfor
}

impl ${object.name} {
    pub fn read(rdr: &mut ArtemisDecoder, header_size: usize) -> FrameReadAttempt<ObjectUpdate, io::Error>
    {
        ## let a = rdr.position();
        ## let parse = ${object.name} {
        ##     % for field in object.fields:
        ##     ${field.name}: {
        ##         trace!("Reading field {}::{}", "${object.name}", "${field.name}");
        ##         ${read_field("rdr", field)}
        ##     },
        ##     % endfor
        ## };
        ## let b = rdr.position();
        ## FrameReadAttempt::Ok((b - a + header_size as u64) as usize, ObjectUpdate::${object.name}(parse))
        FrameReadAttempt::Closed
    }
}
% endfor
