USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_acier_epicor]    Script Date: 2026-04-20 10:38:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_acier_epicor](
	[uid] [int] IDENTITY(1000,1) NOT NULL,
	[cie] [nvarchar](10) NOT NULL,
	[matiere] [nvarchar](50) NOT NULL,
	[epais] [decimal](28, 4) NULL,
	[gauge] [int] NULL,
	[larg] [decimal](28, 4) NULL,
	[texture] [nvarchar](10) NOT NULL,
	[peinture] [nvarchar](20) NOT NULL,
	[couleur] [int] NOT NULL,
	[priorite] [int] NOT NULL,
	[code_epic] [nvarchar](20) NOT NULL,
	[active] [bit] NOT NULL,
	[commentaire] [nvarchar](max) NULL,
	[codeqc] [nvarchar](50) NULL,
	[code17] [nvarchar](50) NULL,
	[partnum_indirect] [nvarchar](50) NOT NULL,
	[leadtime_indirect] [int] NOT NULL,
	[lot_econo_indirect] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_cie]  DEFAULT ('') FOR [cie]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_couleur]  DEFAULT ((0)) FOR [couleur]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_priorite]  DEFAULT ((1)) FOR [priorite]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_active]  DEFAULT ((1)) FOR [active]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_commentaire]  DEFAULT ('') FOR [commentaire]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_codeqc]  DEFAULT ('') FOR [codeqc]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_code17]  DEFAULT ('') FOR [code17]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_partnum_indirect]  DEFAULT ('') FOR [partnum_indirect]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_leadtime_indirect]  DEFAULT ((0)) FOR [leadtime_indirect]
GO

ALTER TABLE [dbo].[uni_acier_epicor] ADD  CONSTRAINT [DF_uni_acier_epicor_lot_econo_indirect]  DEFAULT ((0)) FOR [lot_econo_indirect]
GO

