USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_panneau]    Script Date: 2026-04-20 11:36:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_panneau](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[largeur] [decimal](28, 4) NULL,
	[hauteur] [decimal](28, 4) NULL,
	[fini_int] [int] NULL,
	[fini_ext] [int] NULL,
	[parechoc_int] [int] NULL,
	[parechoc_ext] [int] NULL,
	[lambrissage] [int] NULL,
	[plaque_prot_int] [int] NULL,
	[plaque_prot_ext] [int] NULL,
	[trx_cloison_uid] [int] NOT NULL,
	[trx_groupe_uid] [int] NULL,
	[pos_x] [decimal](18, 4) NULL,
	[pos_y] [decimal](18, 4) NULL,
	[pos_z] [decimal](18, 4) NULL,
	[epaisseur] [decimal](18, 4) NULL,
	[comment] [nvarchar](max) NULL,
 CONSTRAINT [trx_panneau_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

