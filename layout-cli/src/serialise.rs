use serde::Serialize;
use serde::ser::SerializeSeq;
use typst::layout::Frame;
use typst::layout::FrameItem;

pub struct SerializableFrame(pub Frame);

impl Serialize for SerializableFrame {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let SerializableFrame(frame) = self;
        let mut seq = serializer.serialize_seq(Some(frame.layer()))?;
        for (point, item) in frame.items() {
            let serialised_item = serialise_item(item);

            if None == serialised_item {
                continue;
            }

            let full_entry = serde_json::json!({
                "location": {
                    "x": format!("{:?}", point.x),
                    "y": format!("{:?}", point.y),
                },
                "item": serialised_item
            });
            seq.serialize_element(&full_entry)?;
            dbg!(point);
            dbg!(item);
        }
        seq.end()
    }
}

fn serialise_item(item: &FrameItem) -> Option<serde_json::Value> {
    match item {
        FrameItem::Text(x) => Some(serde_json::json!({
            "type": "text",
            "content": x.text
        })),
        // FrameItem::Group(x) => serde_json::json!({
        //     "type": "group",
        // }),
        // FrameItem::Shape(shape, span) => serde_json::json!({
        //     "type": "shape",
        // }),
        // _ => serde_json::json!({
        //     "type": "something else..."
        // }),
        _ => None,
    }
}
