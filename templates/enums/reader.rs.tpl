<% import rust %>\
${rust.header()}

use packet::enums::*;

% for enum in _enums:
impl From<u32> for ${enum.name} {
    fn from(n: u32) -> ${enum.name} {
        match n {
            % for case in enum.consts:
            ${case.aligned_hex_value} => ${enum.name}::${case.name},
            % endfor
            val => ${enum.name}::__Unknown(val as u32)
        }
    }
}

% endfor
