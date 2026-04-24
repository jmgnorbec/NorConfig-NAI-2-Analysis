USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_da_document]    Script Date: 2026-04-20 10:30:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_da_document](
	[UID] [int] IDENTITY(1000,1) NOT NULL,
	[type] [nvarchar](50) NOT NULL,
	[nom] [nvarchar](100) NOT NULL,
	[priority] [int] NOT NULL,
	[condition] [text] NOT NULL,
	[lang] [nvarchar](10) NOT NULL,
	[format] [nvarchar](50) NOT NULL,
	[echelle] [nvarchar](50) NOT NULL,
	[dim_marges] [decimal](28, 4) NOT NULL,
	[dim_cartouche] [decimal](28, 4) NOT NULL,
	[dpi_deprecated] [int] NOT NULL,
	[pix_contour_deprecated] [int] NOT NULL,
	[pix_marges_deprecated] [int] NOT NULL,
	[pix_cassette_deprecated] [int] NOT NULL,
 CONSTRAINT [PK_sys_da_document] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_type]  DEFAULT ('') FOR [type]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_nom]  DEFAULT ('') FOR [nom]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_priority]  DEFAULT ((9)) FOR [priority]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_condition]  DEFAULT ('') FOR [condition]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_lang]  DEFAULT ('') FOR [lang]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_format]  DEFAULT ('') FOR [format]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_echelle]  DEFAULT ('0.25=1.0') FOR [echelle]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_dim_marges]  DEFAULT ((0)) FOR [dim_marges]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_dim_cartouche]  DEFAULT ((0)) FOR [dim_cartouche]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_dpi]  DEFAULT ((100)) FOR [dpi_deprecated]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_pix_contour]  DEFAULT ((3)) FOR [pix_contour_deprecated]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_pix_marges]  DEFAULT ((30)) FOR [pix_marges_deprecated]
GO

ALTER TABLE [dbo].[sys_da_document] ADD  CONSTRAINT [DF_sys_da_document_pix_cassette]  DEFAULT ((190)) FOR [pix_cassette_deprecated]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'chambre, porte' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_da_document', @level2type=N'COLUMN',@level2name=N'type'
GO

