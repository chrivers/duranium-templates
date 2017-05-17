from transwarp.template import context

##### header #####

def header():
    return \
        "// ------------------------------------------\n" \
        "// Generated by Transwarp\n" \
        "//\n" \
        "// THIS FILE IS AUTOMATICALLY GENERATED.\n" \
        "// DO NOT EDIT. ALL CHANGES WILL BE LOST.\n" \
        "// ------------------------------------------"

##### type handling #####

primitive_types = {
    "bool8", "bool16", "bool32",
    "u8", "u16", "u32", "u64",
    "i8", "i16", "i32", "i64",
    "f32", "f64",
}

ref_types = {
    "string",
    "struct",
    "ascii_string",
    "array",
    "map"
}

declare_map = {
    "string": "String",
    "ascii_string": "AsciiString",
}

def declare_struct_type(tp):
    if not tp:
        raise ValueError("Empty type")
    elif tp.name in declare_map:
        return declare_map[tp.name]
    elif tp.name in primitive_types:
        return tp.name
    elif tp.name == "array":
        return "Vec<%s>" % declare_struct_type(tp[0])
    elif tp.name == "struct":
        return "structs::%s" % tp[0].name
    elif tp.name == "enum":
        return "Size<%s, enums::%s>" % (declare_struct_type(tp[0]), tp[1].name)
    elif tp.name == "map":
        return "EnumMap<enums::%s, %s>" % (tp[0].name, declare_struct_type(tp[1]))
    elif tp.name == "option":
        return "Option<%s>" % declare_struct_type(tp[0])
    elif tp.name == "bitflags":
        return "enums::%s" % tp[1].name
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def declare_update_type(tp):
    if tp.name == "map":
        return "EnumMap<enums::%s, Field<%s>>" % (tp[0].name, declare_struct_type(tp[1]))
    else:
        return "Field<%s>" % declare_struct_type(tp)

##### struct fields #####

def write_struct_field(fieldname, type):
    if type.name in ref_types:
        return "wtr.write(&%s)?" % fieldname
    else:
        return "wtr.write(%s)?" % fieldname

##### updates fields #####

def read_update_field(type):
    if type.name == "map":
        return "rdr.read_struct()?"
    else:
        return "rdr.read()?"

def write_update_field(fieldname, type):
    if type.name == "string":
        return "wtr.write(%s.as_ref())?" % fieldname
    elif type.name == "map":
        return "wtr.write_struct(&%s)?" % fieldname
    else:
        return "wtr.write(%s)?" % (fieldname)

##### packets #####

def get_packet(name):
    packets = context["packets"]
    if "::" in name:
        packetname, casename = name.split("::",1)
        return packets.get(packetname).fields.get(casename)
    else:
        return packets.get(name)

def get_parser(name):
    return context["parsers"].get(name)

def get_packet_padding(packet, name):
    if name == "valueInt":
        return 1 - len(packet.fields)
    elif name == "valueFourInts":
        return 4 - len(packet.fields)
    else:
        return 0

def generate_packet_ids(parsername):
    res = {}
    for field in get_parser(parsername).fields:
        if field.type.name == "struct":
            res[field.type[0].name] = (field.type, field.name, None, None)
        elif field.type.name == "parser":
            prs = get_parser(field.type[0].name)
            for fld in prs.fields:
                res[fld.type[0].name] = (fld.type, field.name, fld.name, prs.arg)
    return res
