USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_notify_recipient]    Script Date: 2026-04-20 10:36:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_notify_recipient](
	[uid] [int] IDENTITY(1000,1) NOT NULL,
	[context] [nvarchar](50) NOT NULL,
	[ordinal] [int] NOT NULL,
	[title] [nvarchar](50) NOT NULL,
	[email] [nvarchar](127) NOT NULL,
 CONSTRAINT [PK_sys_notify_recipient] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_notify_recipient] ADD  CONSTRAINT [DF_sys_notify_recipient_context_uid]  DEFAULT ('') FOR [context]
GO

ALTER TABLE [dbo].[sys_notify_recipient] ADD  CONSTRAINT [DF_sys_notify_recipient_ordinal]  DEFAULT ((1)) FOR [ordinal]
GO

ALTER TABLE [dbo].[sys_notify_recipient] ADD  CONSTRAINT [DF_sys_notify_recipient_title]  DEFAULT ('') FOR [title]
GO

ALTER TABLE [dbo].[sys_notify_recipient] ADD  CONSTRAINT [DF_sys_notify_recipient_email]  DEFAULT ('') FOR [email]
GO

