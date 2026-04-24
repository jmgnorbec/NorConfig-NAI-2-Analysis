USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_da_page]    Script Date: 2026-04-20 10:31:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_da_page](
	[UID] [int] IDENTITY(1000,1) NOT NULL,
	[sys_da_document_UID] [int] NOT NULL,
	[no] [int] NOT NULL,
	[type] [nvarchar](50) NOT NULL,
	[nom] [nvarchar](100) NULL,
	[condition] [text] NULL,
	[pix_padding] [int] NOT NULL,
	[page_break_before] [bit] NOT NULL,
	[page_break_after] [bit] NOT NULL,
 CONSTRAINT [PK_sys_da_page] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_da_page] ADD  CONSTRAINT [DF_sys_da_page_no]  DEFAULT ((0)) FOR [no]
GO

ALTER TABLE [dbo].[sys_da_page] ADD  CONSTRAINT [DF_sys_da_page_type]  DEFAULT ('') FOR [type]
GO

ALTER TABLE [dbo].[sys_da_page] ADD  CONSTRAINT [DF_sys_da_page_pix_padding]  DEFAULT ((0)) FOR [pix_padding]
GO

ALTER TABLE [dbo].[sys_da_page] ADD  CONSTRAINT [DF_sys_da_page_force_page_break]  DEFAULT ((0)) FOR [page_break_before]
GO

ALTER TABLE [dbo].[sys_da_page] ADD  CONSTRAINT [DF_sys_da_page_page_break_after]  DEFAULT ((0)) FOR [page_break_after]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type de page (document, groupe, chambre, porte) - détermine l''élément d''occurence (driver)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_da_page', @level2type=N'COLUMN',@level2name=N'type'
GO

