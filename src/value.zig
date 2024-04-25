// Each chunk will contain a list of the values
pub const Value = struct {
    data: u32,

    pub fn init(v: u32) Value {
        return Value{
            .data = v,
        };
    }
};
