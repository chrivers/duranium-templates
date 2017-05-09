<% import rust %>\
${rust.header()}

use std::io::Result;

use ::wire::{ArtemisEncoder, CanEncode, EnumMap, RangeEnum};
use ::wire::{ArtemisUpdateEncoder, CanEncodeUpdate};
use ::packet::enums::{ConsoleType, ConsoleStatus, ShipIndex, TubeIndex, TubeStatus, OrdnanceType, UpgradeType};

impl CanEncode for EnumMap<ConsoleType, ConsoleStatus> where
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_enum8(*elm)?;
        }
        Ok(())
    }
}

impl CanEncode for EnumMap<ShipIndex, bool> where
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_bool8(*elm)?;
        }
        Ok(())
    }
}

impl<T> CanEncode for EnumMap<ShipIndex, T> where
    T: CanEncode
{
    fn write(&self, wtr: &mut ArtemisEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(elm)?;
        }
        Ok(())
    }
}

impl CanEncodeUpdate for EnumMap<TubeIndex, Option<TubeStatus>> where
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_enum8(elm)?;
        }
        Ok(())
    }
}

impl CanEncodeUpdate for EnumMap<TubeIndex, Option<OrdnanceType>> where
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_enum8(elm)?;
        }
        Ok(())
    }
}

impl CanEncodeUpdate for EnumMap<UpgradeType, Option<bool>> where
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write_bool8(elm)?;
        }
        Ok(())
    }
}

impl<E, V> CanEncodeUpdate for EnumMap<E, Option<V>> where
    E: RangeEnum,
    V: CanEncode,
{
    fn write(&self, wtr: &mut ArtemisUpdateEncoder) -> Result<()>
    {
        for elm in self.get_ref() {
            wtr.write(&elm.as_ref())?;
        }
        Ok(())
    }
}
