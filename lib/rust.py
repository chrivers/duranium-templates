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

def is_ref_type(typ):
    return typ.name in ("string", "struct", "ascii_string", "array", "map", "option", "bool8", "bool16", "bool32")

primitive_map = {
    "bool8": "bool8",
    "bool16": "bool16",
    "bool32": "bool32",

    "u8": "u8",
    "u16": "u16",
    "u32": "u32",
    "u64": "u64",

    "i8": "i8",
    "i16": "i16",
    "i32": "i32",

    "f32": "f32",
    "string": "string",
}

generic_types = {
    "bitflags",
    "struct",
    "map",
    "array",
    "string",
    "option",
    "bool8",
    "bool16",
    "bool32",
}

declare_map = {
    "string": "String",
    "ascii_string": "String",
}

def declare_struct_type(tp):
    if not tp:
        raise ValueError("Empty type")
    elif tp.name in declare_map:
        return declare_map[tp.name]
    elif tp.name in primitive_map:
        return primitive_map[tp.name]
    elif tp.name == "array":
        return "Vec<%s>" % declare_struct_type(tp[0])
    elif tp.name == "struct":
        return tp[0].name
    elif tp.name == "enum":
        return "Size<%s, %s>" % (tp[0].name, tp[1].name)
    elif tp.name == "map":
        return "EnumMap<%s, %s>" % (tp[0].name, declare_struct_type(tp[1]))
    elif tp.name == "option":
        return "Option<%s>" % declare_struct_type(tp[0])
    elif tp.name == "bitflags":
        return tp[1].name
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def declare_update_type(tp):
    if tp.name == "map":
        return "EnumMap<%s, Option<%s>>" % (tp[0].name, declare_struct_type(tp[1]))
    else:
        return "Option<%s>" % declare_struct_type(tp)

def reader_function(tp):
    if tp.name in generic_types:
        return "read"
    elif tp.name in {"f32", "f64", "u8", "u16", "u32", "u64", "i8", "i16", "i32", "i64"}:
        return "read"
    elif tp.name in primitive_map:
        return "read_%s" % primitive_map[tp.name]
    elif tp.name == "ascii_string":
        return "read_ascii_string"
    elif tp.name == "enum":
        return "read"
    else:
        raise TypeError("No reader function for [%r]" % tp)

def writer_function(tp):
    if tp.name in generic_types:
        return "write"
    elif tp.name in primitive_map:
        return "write_%s" % primitive_map[tp.name]
    elif tp.name == "ascii_string":
        return "write_ascii_string"
    else:
        raise TypeError("No writer function for [%r]" % tp)

##### struct fields #####

def read_struct_field(type):
    if type.name == "array":
        if type[1]:
            if len(type[1].name) <= 4:
                return "rdr.read_array_u8(%s)?" % (type[1].name)
            else:
                return "rdr.read_array_u32(%s)?" % (type[1].name)
        else:
            return "rdr.read_array()?"
    else:
        return "rdr.%s()?" % reader_function(type)

def write_struct_field(fieldname, type, ref):
    if type.name == "array" and len(type._args) == 2:
        if len(type[1].name) <= 4:
            return "wtr.write_array_u8(%s, %s)?" % (fieldname, type[1].name)
        else:
            return "wtr.write_array_u32(%s, %s)?" % (fieldname, type[1].name)
    elif type.name == "enum":
        return "wtr.write(&%s)?" % (fieldname)
    else:
        if is_ref_type(type) and not ref:
            fieldname = "&%s" % fieldname
        return "wtr.%s(%s)?" % (writer_function(type), fieldname)

##### updates fields #####

def read_update_field(type):
    if type.name == "map":
        return "rdr.read_struct()?"
    else:
        return read_struct_field(type)

def write_update_field(fieldname, type):
    if type.name in {"string", "bitflags", "enum", "bool8", "bool16", "bool32"}:
        return "wtr.write(&%s.as_ref())?" % (fieldname)
    elif type.name == "map":
        return "wtr.write_struct(&%s)?" % (fieldname)
    elif type.name == "enum":
        return "wtr.write(&%s)?" % (fieldname)
    else:
        return "wtr.%s(&%s)?" % (writer_function(type), fieldname)

##### field refs #####

def ref_struct_field(fld):
    if is_ref_type(fld.type):
        return "ref %s" % fld.name
    else:
        return fld.name

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
