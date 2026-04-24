USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_desc_gen]    Script Date: 2026-04-20 10:31:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_desc_gen](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[type] [nvarchar](50) NOT NULL,
	[no_ligne] [int] NOT NULL,
	[condition] [nvarchar](255) NOT NULL,
	[fr] [text] NOT NULL,
	[en] [text] NOT NULL,
	[bol] [text] NULL,
	[eol] [text] NULL,
 CONSTRAINT [PK_sys_desc_gen] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_desc_gen] ADD  CONSTRAINT [DF_sys_desc_gen_no_ligne]  DEFAULT ((9000)) FOR [no_ligne]
GO

ALTER TABLE [dbo].[sys_desc_gen] ADD  CONSTRAINT [DF_sys_desc_gen_condition]  DEFAULT ('') FOR [condition]
GO

ALTER TABLE [dbo].[sys_desc_gen] ADD  CONSTRAINT [DF_sys_desc_gen_fr]  DEFAULT ('') FOR [fr]
GO

ALTER TABLE [dbo].[sys_desc_gen] ADD  CONSTRAINT [DF_sys_desc_gen_en]  DEFAULT ('') FOR [en]
GO

ALTER TABLE [dbo].[sys_desc_gen] ADD  CONSTRAINT [DF_sys_desc_gen_bol]  DEFAULT ('') FOR [bol]
GO

ALTER TABLE [dbo].[sys_desc_gen] ADD  CONSTRAINT [DF_sys_desc_gen_eol]  DEFAULT ('') FOR [eol]
GO

