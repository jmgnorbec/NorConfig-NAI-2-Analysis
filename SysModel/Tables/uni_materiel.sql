USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_materiel]    Script Date: 2026-04-20 10:41:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_materiel](
	[uid] [int] IDENTITY(1,1) NOT NULL,
	[matiere] [nvarchar](50) NULL,
	[couleur] [int] NULL,
	[texture] [nvarchar](50) NULL,
	[profile] [nvarchar](50) NULL,
	[gauge] [int] NULL,
	[type_peinture] [nvarchar](50) NULL,
	[actif] [bit] NULL,
	[ref_item_uid] [nvarchar](150) NULL,
	[Nai_pricing_nom] [nvarchar](150) NULL,
	[Nai_pricing_code] [nvarchar](150) NULL,
	[bouchon] [nvarchar](50) NULL,
	[silicone] [nvarchar](50) NULL,
	[crayon] [nvarchar](50) NULL,
	[coin_prot] [nvarchar](50) NULL,
	[vis_trois_quart] [nvarchar](50) NULL,
	[nom_intran_inventor] [nvarchar](150) NULL,
	[gris_blanc] [nvarchar](50) NULL,
	[largpan_max] [decimal](28, 4) NOT NULL,
	[inv_epais_str] [nvarchar](50) NULL,
	[type_matiere] [nvarchar](50) NULL,
 CONSTRAINT [PK_uni_materiel] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_Materiel] UNIQUE NONCLUSTERED 
(
	[matiere] ASC,
	[type_matiere] ASC,
	[gauge] ASC,
	[couleur] ASC,
	[profile] ASC,
	[texture] ASC,
	[type_peinture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[uni_materiel] ADD  CONSTRAINT [DF_uni_materiel_actif]  DEFAULT ((1)) FOR [actif]
GO

ALTER TABLE [dbo].[uni_materiel] ADD  CONSTRAINT [DF_uni_materiel_largpan_max]  DEFAULT ((46.5)) FOR [largpan_max]
GO

