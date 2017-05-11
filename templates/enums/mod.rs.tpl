<% import rust %>\
${rust.header()}

use std::default::Default;

use ::wire::RangeEnum;
use ::wire::types::*;

pub mod reader;
pub mod writer;

% for enum in enums.without("FrameType"):
%if enum.name in ("AudioMode", "ConsoleType"):
#[derive(Eq,Hash)]
%endif
%if enum.name == "ObjectType":
#[allow(non_camel_case_types)]
%endif
#[derive(PartialEq,Debug,Copy,Clone)]
pub enum ${enum.name}
{
    % for case in enum.fields:
    ${case.name},
    % endfor
    __Unknown(u32),
}

impl Default for ${enum.name} {
    fn default() -> Self { ${enum.name}::${enum.fields[0].name} }
}

impl RangeEnum for ${enum.name} {
    const HIGHEST: usize = ${enum.fields[-1].aligned_hex_value};
}
% endfor
pub mod frametype {
    #![allow(non_upper_case_globals)]
    % for case in enums.get("FrameType").fields:
    pub const ${case.aligned_name} : u32 = ${case.aligned_hex_value};
    % endfor
}

% for flag in flags:
bitflags!
{
    pub flags ${flag.name}: u32
    {
        % for field in flag.fields:
        const ${field.aligned_name} = ${field.aligned_hex_value},
        % endfor
    }
}

impl Default for ${flag.name} {
    fn default() -> Self { Self::empty() }
}
% endfor


impl Repr<u32> for Option<Size<u32, ConsoleType>>
{
    fn decode(x: u32) -> Self {
        match x {
            0 => None,
            n => Some(Size::new(ConsoleType::from(n - 1))
            )
        }
    }

    fn encode(x: Self) -> u32 {
        x.map_or(0, |ct| u32::from(ct) + 1)
    }
}
