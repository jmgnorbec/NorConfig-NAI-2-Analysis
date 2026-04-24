USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_inv_bom]    Script Date: 2026-04-20 11:35:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_inv_bom](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
	[Epaisseur] [decimal](18, 4) NULL,
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
	[ParentFileName] [nvarchar](150) NULL,
	[refKey] [nvarchar](50) NULL,
	[Injection_Montage] [bit] NULL,
	[Coupage_Bois] [bit] NULL,
	[Partnum] [nvarchar](100) NULL,
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
	[IsItemLibrary] [bit] NULL,
	[IsNSF] [bit] NULL,
	[IsPhantom] [bit] NULL,
	[IsRefState] [bit] NULL,
	[Family] [nvarchar](50) NULL,
	[MatCategory] [nvarchar](50) NULL,
	[Type] [nvarchar](20) NULL,
	[Mass] [float] NULL,
	[TopParentFamily] [nvarchar](50) NULL,
	[TopParentFileName] [nvarchar](120) NULL,
	[TopParentTag] [nvarchar](60) NULL,
	[UserName] [nvarchar](50) NULL,
	[Volume] [float] NULL,
	[IsBoisCap] [bit] NULL,
	[MatName] [nchar](50) NULL,
	[InvMatName] [nchar](50) NULL,
	[TopParentDisplayName] [nvarchar](150) NULL,
	[PartUid] [float] NULL,
	[ParentUid] [float] NULL,
	[ModelVersion] [float] NULL,
	[IsNextGrip] [bit] NULL,
	[DueDate] [datetime] NULL,
	[TrumpfCoupage] [bit] NULL,
	[PrimaCoupage] [bit] NULL,
	[PrimaPliage] [bit] NULL,
	[opr_asm] [bit] NULL,
	[opr_inj] [bit] NULL,
	[IsAutoBendLimitation] [bit] NULL,
	[IsAutoCutLimitation] [bit] NULL,
	[Consom] [nchar](50) NULL,
	[IsKanban] [bit] NULL,
	[Mat_Uid] [int] NULL,
	[QuoteNum] [int] NULL,
	[QuoteLine] [int] NULL,
	[VBType] [nvarchar](150) NULL,
	[InvPartNumber] [nvarchar](120) NULL,
	[CoupagePVC] [bit] NULL,
	[PartnumMaster] [nvarchar](100) NULL,
 CONSTRAINT [trx_inv_bom_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_Existing_Product]  DEFAULT ((0)) FOR [Existing_Product]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_CaleRollFormer]  DEFAULT ((0)) FOR [CaleRollFormer]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_ModelVersion]  DEFAULT ((0)) FOR [ModelVersion]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_IsTrumpf]  DEFAULT ((0)) FOR [TrumpfCoupage]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_IsPrimaCoupage]  DEFAULT ((0)) FOR [PrimaCoupage]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_IsPrimaPliage]  DEFAULT ((0)) FOR [PrimaPliage]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_opr_asm]  DEFAULT ((0)) FOR [opr_asm]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_opr_inj]  DEFAULT ((0)) FOR [opr_inj]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_QuoteNum]  DEFAULT ((0)) FOR [QuoteNum]
GO

ALTER TABLE [dbo].[trx_inv_bom] ADD  CONSTRAINT [DF_trx_inv_bom_QuoteLine]  DEFAULT ((0)) FOR [QuoteLine]
GO

