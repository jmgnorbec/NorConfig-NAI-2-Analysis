USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_notify_presets]    Script Date: 2026-04-20 10:35:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_notify_presets](
	[uid] [int] IDENTITY(1000,1) NOT NULL,
	[context] [nvarchar](50) NOT NULL,
	[ordinal] [int] NOT NULL,
	[name] [nvarchar](128) NOT NULL,
	[subject] [nvarchar](255) NOT NULL,
	[body] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_sys_notify_content] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_notify_presets] ADD  CONSTRAINT [DF_sys_notify_content_context_uid]  DEFAULT ('') FOR [context]
GO

ALTER TABLE [dbo].[sys_notify_presets] ADD  CONSTRAINT [DF_sys_notify_content_ordinal]  DEFAULT ((1)) FOR [ordinal]
GO

ALTER TABLE [dbo].[sys_notify_presets] ADD  CONSTRAINT [DF_sys_notify_content_name]  DEFAULT ('') FOR [name]
GO

ALTER TABLE [dbo].[sys_notify_presets] ADD  CONSTRAINT [DF_sys_notify_content_subject]  DEFAULT ('') FOR [subject]
GO

ALTER TABLE [dbo].[sys_notify_presets] ADD  CONSTRAINT [DF_sys_notify_content_body]  DEFAULT ('') FOR [body]
GO

