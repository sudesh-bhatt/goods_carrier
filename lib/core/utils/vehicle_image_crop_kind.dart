/// Crop presets for vehicle form image slots (Figma `1:185`).
enum VehicleImageCropKind {
  /// Hero banner — ~16:9, max 1280×720.
  vehicleHero,

  /// Driving license — 4:3 document, max 1280×960.
  license,

  /// Profile selfie — 1:1 square, max 512×512.
  profile,
}
