USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_couleurs]    Script Date: 2026-04-20 10:39:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_couleurs](
	[uid] [int] IDENTITY(1,1) NOT NULL,
	[Couleur] [nvarchar](150) NULL,
	[Code_QC] [nvarchar](50) NULL,
	[Code_17] [nvarchar](50) NULL,
	[Couleur_en] [nvarchar](150) NULL,
	[R] [int] NULL,
	[G] [int] NULL,
	[B] [int] NULL,
	[bouchon] [nvarchar](50) NULL,
	[gris_blanc] [nvarchar](50) NULL,
	[silicone] [nvarchar](50) NULL,
	[crayon] [nvarchar](50) NULL,
	[coin_prot] [nvarchar](50) NULL,
	[vis_trois_quart] [nvarchar](50) NULL,
	[IsTurnOver] [bit] NULL,
 CONSTRAINT [PK_uni_couleurs] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_Couleur] UNIQUE NONCLUSTERED 
(
	[Couleur] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_Couleur_en] UNIQUE NONCLUSTERED 
(
	[Couleur_en] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[uni_couleurs] ADD  CONSTRAINT [DF_uni_couleurs_bouchon]  DEFAULT ('') FOR [bouchon]
GO

ALTER TABLE [dbo].[uni_couleurs] ADD  CONSTRAINT [DF_uni_couleurs_gris_blanc]  DEFAULT ('') FOR [gris_blanc]
GO

ALTER TABLE [dbo].[uni_couleurs] ADD  CONSTRAINT [DF_uni_couleurs_silicone]  DEFAULT ('') FOR [silicone]
GO

ALTER TABLE [dbo].[uni_couleurs] ADD  CONSTRAINT [DF_uni_couleurs_crayon]  DEFAULT ('') FOR [crayon]
GO

ALTER TABLE [dbo].[uni_couleurs] ADD  CONSTRAINT [DF_uni_couleurs_coin_prot]  DEFAULT ('') FOR [coin_prot]
GO

ALTER TABLE [dbo].[uni_couleurs] ADD  CONSTRAINT [DF_uni_couleurs_vis_trois_quart]  DEFAULT ('') FOR [vis_trois_quart]
GO

ALTER TABLE [dbo].[uni_couleurs] ADD  CONSTRAINT [DF_uni_couleurs_IsTurnOver]  DEFAULT ((1)) FOR [IsTurnOver]
GO

