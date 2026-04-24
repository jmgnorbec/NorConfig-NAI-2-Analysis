USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_chambre_renfort]    Script Date: 2026-04-20 11:31:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_chambre_renfort](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[no] [int] NULL,
	[largeur] [decimal](28, 4) NULL,
	[hauteur] [decimal](28, 4) NULL,
	[pos] [int] NULL,
	[trx_chambre_UID] [int] NOT NULL,
 CONSTRAINT [PK_trx_chambre_renfort] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_chambre_renfort]  WITH CHECK ADD  CONSTRAINT [trx_chambre_renfort_trx_chambre_FK] FOREIGN KEY([trx_chambre_UID])
REFERENCES [dbo].[trx_chambre] ([UID])
GO

ALTER TABLE [dbo].[trx_chambre_renfort] CHECK CONSTRAINT [trx_chambre_renfort_trx_chambre_FK]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valeurs: 0.Mur int  1.Mur ext  2.Plafond int  3.Plafond ext' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_chambre_renfort', @level2type=N'COLUMN',@level2name=N'pos'
GO

