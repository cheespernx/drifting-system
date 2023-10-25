Config = {}

Config.Debug = false
Config.Use4Tyres = false

Config.Bind = {
  Key = "O",
  Description = "Blocar o diferencial (Drift)",
  Command = "drift"
}

Config.Timers = {
  ActivateDriftMode = 8000,
  ComponentInstall = 35000
}

Config.Items = {
  Differential = {
    ItemName = "differential",
    Quantity = 1
  },
  DriftingTyres = {
    ItemName = "drifting_tyres",
    Quantity = 4
  },
  SteerKit = {
    ItemName = "steer_kit",
    Quantity = 1
  }
}

Config.WearPartsHandling = {
  Full = {
    fLowSpeedTractionLossMult = 0.0,
    fSteeringLock = 68.0
  },
  Half = {
    fLowSpeedTractionLossMult = 0.01,
    fSteeringLock = 58.0
  },
  Low = {
    fLowSpeedTractionLossMult = 0.1,
    fSteeringLock = 30.0
  }
}

Config.TyresModification = {
  fDriveInertia = 0.80,
  fBrakeForce = 0.90,
  fBrakeBiasFront = 0.20,
  fHandBrakeForce = 0.90,
  fLowSpeedTractionLossMult = 0.0
}

Config.DifferentialModifications = {
  fClutchChangeRateScaleUpShift = 180.0,
  fClutchChangeRateScaleDownShift = 75.0,
  fTractionCurveMax = 0.60,
  fTractionCurveMin = 1.15,
  fTractionCurveLateral = 30.0,
  fTractionBiasFront = 0.495
}

Config.AngleKitModifications = {
  fSteeringLock = 68.0,
  fCamberStiffnesss = 0.0,
  fSuspensionForce = 4.0,
  fSuspensionCompDamP = 1.6,
  fSuspensionReboundDamp = 1.0,
  fSuspensionUpperLimit = 0.18,
  fRollCentreHeightFront = 0.34,
  fRollCentreHeightRear = 0.35,
  fAntiRollBarForce = 1.4,
  fAntiRollBarBiasFront = 0.99
}

Config.Tyres = {
  Health = {
    Max = 1000.0,
    Min = 400.0
  },
  Wear = {
    Normal = 0.0,
    Drift = 0.3
  }
}
