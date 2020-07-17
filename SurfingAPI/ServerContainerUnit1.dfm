object ServerContainer1: TServerContainer1
  OldCreateOrder = False
  Height = 271
  Width = 415
  object DSServer1: TDSServer
    Left = 96
    Top = 11
  end
  object DSServerClassCatalogos: TDSServerClass
    OnGetClass = DSServerClassCatalogosGetClass
    Server = DSServer1
    Left = 200
    Top = 11
  end
end
