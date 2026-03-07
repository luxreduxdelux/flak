const META_HEADER: &str = r#"---@meta

---@class flak
flak = {}

"#;
const META_FILE: &str = "meta.lua";
const PATH_SOURCE: &str = "../engine_macro/out";
// Should be "../engine_basic" any other moment, but for now, it's important that it is written out to the working directory for the game.
const PATH_TARGET: &str = "../../main";

//================================================================

fn main() {
    let mut buffer = self::META_HEADER.to_string();

    // Read every file in the class/function/method meta directory.
    for path in std::fs::read_dir(self::PATH_SOURCE)
        .unwrap_or_else(|_| panic!("The path \"{}\" does not exist.", self::PATH_SOURCE))
    {
        // Read the file, remove it, and push its data to the buffer.
        let path = path.expect("Unable to read path.").path();
        let file = std::fs::read_to_string(&path).expect("Unable to read file to string.");
        std::fs::remove_file(&path).expect("Unable to remove file.");

        buffer.push_str(&format!("{}\n\n", file.trim()));
    }

    //================================================================

    // Check if the main path is a folder.
    let path = std::path::Path::new(self::PATH_TARGET);

    if path.is_dir() {
        // Write meta file.
        std::fs::write(format!("{}/{}", self::PATH_TARGET, self::META_FILE), buffer)
            .expect("Unable to write meta file.");
    }
}
