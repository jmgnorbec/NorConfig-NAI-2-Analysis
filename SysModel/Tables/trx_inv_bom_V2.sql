USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_inv_bom_V2]    Script Date: 2026-04-20 11:36:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_inv_bom_V2](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[Projet] [nvarchar](120) NULL,
	[Description] [nvarchar](500) NULL,
	[OccName] [nvarchar](120) NULL,
	[FileName] [nvarchar](120) NULL,
	[Path] [nvarchar](255) NULL,
	[Tag] [nvarchar](60) NULL,
	[ItemSort] [nvarchar](20) NULL,
	[Mat] [nvarchar](500) NULL,
	[Gauge] [nvarchar](20) NULL,
	[FoldX] [decimal](28, 3) NULL,
	[ItemColor] [nvarchar](500) NULL,
	[FoldY] [decimal](28, 3) NULL,
	[FoldC] [decimal](28, 3) NULL,
	[Epaisseur] [decimal](28, 4) NULL,
	[FlatX] [decimal](28, 3) NULL,
	[FlatY] [decimal](28, 3) NULL,
	[Assemblage] [bit] NULL,
	[Injection] [bit] NULL,
	[Finition] [bit] NULL,
	[Expedition] [bit] NULL,
	[Ligne_Acier] [bit] NULL,
	[Coupage] [bit] NULL,
	[Pliage] [bit] NULL,
	[IconPliX] [nvarchar](20) NULL,
	[IconPliY] [nvarchar](20) NULL,
	[PanelType] [nvarchar](50) NULL,
	[PanelConfig] [nvarchar](250) NULL,
	[ParentFileName] [nvarchar](50) NULL,
	[refKey] [nvarchar](50) NULL,
	[Injection_Montage] [bit] NULL,
	[Coupage_Bois] [bit] NULL,
	[Partnum] [nchar](50) NULL,
	[Functional_Value] [nvarchar](250) NULL,
	[Date_Added] [datetime] NULL,
	[Existing_Product] [bit] NULL,
	[CaleRollFormer] [bit] NULL,
	[Renfort] [bit] NULL,
	[Kfacteur] [float] NULL,
	[NSFID] [nchar](10) NULL,
	[ContractID] [nvarchar](20) NULL,
	[GroupID] [nvarchar](20) NULL,
	[IsCale] [bit] NULL,
	[IsCustom] [bit] NULL,
	[IsExtrude] [bit] NULL,
	[IsFlange] [bit] NULL,
	[IsFlatPattern_X] [bit] NULL,
	[IsItemLibrary] [bit] NULL,
	[IsMinDistance_X] [bit] NULL,
	[IsNSF] [bit] NULL,
	[IsPhantom] [bit] NULL,
	[IsRefState] [bit] NULL,
	[IsValidKFactor_X] [bit] NULL,
	[Family] [nvarchar](50) NULL,
	[MatCategory] [nvarchar](50) NULL,
	[Type] [nvarchar](20) NULL,
	[Mass] [float] NULL,
	[ParentDisplayName_X] [nvarchar](120) NULL,
	[TopParentCategory_X] [nvarchar](50) NULL,
	[TopParentFamily] [nvarchar](50) NULL,
	[TopParentFileName] [nvarchar](120) NULL,
	[TopParentIsExtrude_X] [bit] NULL,
	[TopParentTag] [nvarchar](60) NULL,
	[UserName] [nvarchar](50) NULL,
	[Volume] [float] NULL,
	[FileExtension_X] [nchar](10) NULL,
	[ParentFileExtension_X] [nchar](10) NULL,
	[IsBoisCap] [bit] NULL,
	[MatName] [nchar](50) NULL,
	[InvMatName] [nchar](50) NULL,
	[TopParentDisplayName] [nchar](50) NULL,
	[PartUid] [float] NULL,
	[ParentUid] [float] NULL,
	[ModelVersion] [float] NULL,
	[Grain_X] [int] NULL,
	[IsTurnOver_X] [bit] NULL,
	[MatFamily_X] [int] NULL,
	[IsNextGrip] [bit] NULL,
	[DueDate] [datetime] NULL,
	[MotherBPName_X] [nchar](50) NULL,
	[BendProgramName_X] [nchar](50) NULL,
	[TrumpfCoupage] [bit] NULL,
	[PrimaCoupage] [bit] NULL,
	[PrimaPliage] [bit] NULL,
	[IsSurfaceDetect_X] [bit] NULL,
	[opr_asm] [bit] NULL,
	[opr_inj] [bit] NULL,
	[IsAutoBendLimitation] [bit] NULL,
	[IsAutoCutLimitation] [bit] NULL,
	[Consom] [nchar](50) NULL,
	[IsKanban] [bit] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_ModelVersion]  DEFAULT ((0)) FOR [ModelVersion]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_Grain]  DEFAULT ((0)) FOR [Grain_X]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_IsTurnOver]  DEFAULT ((0)) FOR [IsTurnOver_X]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_IsTrumpf]  DEFAULT ((0)) FOR [TrumpfCoupage]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_IsPrimaCoupage]  DEFAULT ((0)) FOR [PrimaCoupage]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_IsPrimaPliage]  DEFAULT ((0)) FOR [PrimaPliage]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_AutoCut]  DEFAULT ((0)) FOR [IsSurfaceDetect_X]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_opr_asm]  DEFAULT ((0)) FOR [opr_asm]
GO

ALTER TABLE [dbo].[trx_inv_bom_V2] ADD  CONSTRAINT [DF_trx_inv_bom_V2_opr_inj]  DEFAULT ((0)) FOR [opr_inj]
GO

