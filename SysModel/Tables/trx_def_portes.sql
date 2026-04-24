USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_def_portes]    Script Date: 2026-04-20 11:33:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_def_portes](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[trx_project_UID] [int] NULL,
	[trx_chambre_UID] [int] NULL,
	[trx_groupe_UID] [int] NULL,
	[Description] [nvarchar](50) NULL,
	[porte_fini_int] [int] NULL,
	[porte_fini_ext] [int] NULL,
	[porte_epaisseur] [int] NULL,
	[cadre_fini_int] [int] NULL,
	[cadre_fini_ext] [int] NULL,
	[cadre_epaisseur] [int] NULL,
	[cadre_jonction_type] [int] NULL,
	[cadre_jonction_coin] [int] NULL,
	[cadre_jonction_scellant] [int] NULL,
	[plaque_int_fini] [int] NULL,
	[plaque_int_hauteur] [decimal](18, 4) NULL,
	[plaque_ext_fini] [int] NULL,
	[plaque_ext_hauteur] [decimal](18, 4) NULL,
	[porte_fen_cong] [int] NULL,
	[porte_fen_refri] [int] NULL,
	[porte_fen_cadre] [int] NULL,
 CONSTRAINT [trx_projectv1_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

