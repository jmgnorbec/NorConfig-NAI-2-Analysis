USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_notify_context]    Script Date: 2026-04-20 10:35:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_notify_context](
	[name] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_sys_notify_context] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_notify_context] ADD  CONSTRAINT [DF_sys_notify_context_name]  DEFAULT ('') FOR [name]
GO

