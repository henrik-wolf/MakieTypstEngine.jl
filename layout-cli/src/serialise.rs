use serde::Serialize;
use serde::ser::{SerializeSeq, SerializeStruct};
use typst::layout::FrameItem;
use typst::layout::{Frame, Point};
use typst::text::Glyph;
use typst::visualize::Geometry;

pub struct SerializableFrame(pub Frame);

pub struct SerialisableGlyph(pub Glyph);

impl Serialize for SerializableFrame {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let SerializableFrame(frame) = self;
        let mut seq = serializer.serialize_seq(Some(frame.layer()))?;
        for (point, item) in frame.items() {
            dbg!(point);
            dbg!(item);
            let serialised_point = serialise_point(point);
            let serialised_type = serialise_type(item);
            let serialised_item = serialise_item(item);

            if None == serialised_item {
                continue;
            }

            let full_entry = serde_json::json!({
                "location": serialised_point,
                "type": serialised_type,
                "content": serialised_item
            });
            seq.serialize_element(&full_entry)?;
        }
        seq.end()
    }
}

impl Serialize for SerialisableGlyph {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let SerialisableGlyph(glyph) = self;
        let mut state = serializer.serialize_struct("Glyph", 3)?;
        state.serialize_field("id", &glyph.id)?;
        state.serialize_field("x_advance", &format!("{:?}", glyph.x_advance))?;
        state.serialize_field("x_offset", &format!("{:?}", glyph.x_offset))?;
        state.end()
    }
}

fn serialise_point(point: &Point) -> serde_json::Value {
    serde_json::json!({
                    "x": format!("{:?}", point.x),
                    "y": format!("{:?}", point.y),
    })
}

fn serialise_type(item: &FrameItem) -> Option<serde_json::Value> {
    match item {
        FrameItem::Text(_) => Some(serde_json::json!("text")),
        FrameItem::Group(_) => Some(serde_json::json!("group")),
        FrameItem::Shape(shape, _) => match shape.geometry {
            Geometry::Line(_) => Some(serde_json::json!("line")),
            _ => None,
        },
        _ => None,
    }
}

fn serialise_item(item: &FrameItem) -> Option<serde_json::Value> {
    match item {
        FrameItem::Text(x) => {
            dbg!(&x.glyphs);
            let wrapped_glyphs: Vec<SerialisableGlyph> = x
                .glyphs
                .iter()
                .map(|g| SerialisableGlyph(g.clone()))
                .collect();
            Some(serde_json::json!({
                "font": x.font.info(),
                "text": x.text,
                "size": format!("{:?}", x.size),
                "glyphs": serde_json::json!(wrapped_glyphs)
            }))
        }
        FrameItem::Group(x) => Some(serde_json::json!(SerializableFrame(x.frame.clone()))),
        FrameItem::Shape(shape, _) => match shape.geometry {
            Geometry::Line(point) => {
                let ser_point = serialise_point(&point);
                let width = shape.stroke.clone().unwrap().thickness;

                Some(serde_json::json!({"to": ser_point, "thickness": format!("{:?}", width)}))
            }
            _ => None,
        },
        // _ => serde_json::json!({
        //     "type": "something else..."
        // }),
        _ => None,
    }
}
