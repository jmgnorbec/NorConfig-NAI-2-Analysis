USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_da_bloc]    Script Date: 2026-04-20 10:30:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_da_bloc](
	[UID] [int] IDENTITY(1000,1) NOT NULL,
	[domaine] [nvarchar](2048) NOT NULL,
	[nom] [nvarchar](100) NOT NULL,
	[type] [nvarchar](50) NOT NULL,
	[contenu] [text] NOT NULL,
	[comment] [text] NOT NULL,
 CONSTRAINT [PK_sys_da_bloc] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_da_bloc] ADD  CONSTRAINT [DF_sys_da_bloc_domaine]  DEFAULT ('') FOR [domaine]
GO

ALTER TABLE [dbo].[sys_da_bloc] ADD  CONSTRAINT [DF_sys_da_bloc_nom]  DEFAULT ('') FOR [nom]
GO

ALTER TABLE [dbo].[sys_da_bloc] ADD  CONSTRAINT [DF_sys_da_bloc_type]  DEFAULT ('') FOR [type]
GO

ALTER TABLE [dbo].[sys_da_bloc] ADD  CONSTRAINT [DF_sys_da_bloc_contenu]  DEFAULT ('') FOR [contenu]
GO

ALTER TABLE [dbo].[sys_da_bloc] ADD  CONSTRAINT [DF_sys_da_bloc_commentaire]  DEFAULT ('') FOR [comment]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'texte ou description ou image ou dessin ou custom' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_da_bloc', @level2type=N'COLUMN',@level2name=N'type'
GO

