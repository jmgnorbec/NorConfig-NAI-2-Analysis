USE [Configurateur]
GO

/****** Object:  Table [dbo].[ref_pan_continu]    Script Date: 2026-04-20 10:24:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ref_pan_continu](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[partnum] [nvarchar](50) NOT NULL,
	[poly] [nvarchar](50) NULL,
	[iso] [nvarchar](50) NULL,
	[film] [nvarchar](50) NULL,
	[butyle] [nvarchar](50) NULL,
	[ruban_mur] [nvarchar](50) NULL,
	[ruban_usine] [nvarchar](50) NULL,
	[etiquette] [nvarchar](50) NULL,
	[catalyste] [nvarchar](50) NULL,
	[pentane] [nvarchar](50) NULL,
	[colle] [nvarchar](50) NULL,
	[laine_roche] [nvarchar](50) NULL,
	[mousse] [nvarchar](50) NULL,
	[joint] [nvarchar](50) NULL,
	[epaisseur] [int] NULL,
	[largeur] [decimal](18, 1) NULL,
	[ldr_polyol] [nvarchar](50) NULL,
	[ldr_catalyst] [nvarchar](50) NULL,
	[rejet_0K_1K] [decimal](18, 4) NULL,
	[rejet_1K_4K] [decimal](18, 4) NULL,
	[rejet_4K] [decimal](18, 4) NULL,
 CONSTRAINT [PK_ref_pan_continu] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ref_pan_continu] ADD  CONSTRAINT [DF_ref_pan_continu_etiquette]  DEFAULT ('') FOR [etiquette]
GO

ALTER TABLE [dbo].[ref_pan_continu] ADD  CONSTRAINT [DF_ref_pan_continu_laine_roche]  DEFAULT ('') FOR [laine_roche]
GO

ALTER TABLE [dbo].[ref_pan_continu] ADD  CONSTRAINT [DF_ref_pan_continu_ldr_polyol]  DEFAULT ('') FOR [ldr_polyol]
GO

ALTER TABLE [dbo].[ref_pan_continu] ADD  CONSTRAINT [DF_ref_pan_continu_ldr_catalyst]  DEFAULT ('') FOR [ldr_catalyst]
GO

