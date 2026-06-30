import 'package:flutter/material.dart';

import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../shared/domain/entities/driver_vehicle.dart';
import '../../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../../shared/presentation/widgets/sheets/app_picker_bottom_sheet.dart';

/// Shared shipment / trip form pickers — same chrome on customer and driver flows.
abstract final class ShipmentFormPickers {
  ShipmentFormPickers._();

  static Future<VehicleType?> showVehicleType(BuildContext context) {
    return AppPickerBottomSheet.show<VehicleType>(
      context: context,
      title: context.l10n.shipmentFormVehicleRequirement,
      items: VehicleType.values
          .map(
            (v) => AppPickerItem<VehicleType>(
              value: v,
              label: v.label,
              subtitle: v.capacityLabel,
            ),
          )
          .toList(),
    );
  }

  static Future<DriverVehicle?> showDriverVehicle(
    BuildContext context, {
    required List<DriverVehicle> vehicles,
  }) {
    return AppPickerBottomSheet.show<DriverVehicle>(
      context: context,
      title: context.l10n.driverSelectVehicle,
      items: vehicles
          .map(
            (vehicle) => AppPickerItem<DriverVehicle>(
              value: vehicle,
              label: vehicle.displayTypeName,
              subtitle: '${vehicle.vehicleNumber} · ${vehicle.capacityLabel}',
            ),
          )
          .toList(),
    );
  }

  static Future<String?> showWeightUnit(BuildContext context) {
    return AppPickerBottomSheet.show<String>(
      context: context,
      title: context.l10n.shipmentFormEstWeightType,
      items: const [
        AppPickerItem(value: 'KG', label: 'KG'),
        AppPickerItem(value: 'Ton', label: 'Ton'),
      ],
    );
  }
}
