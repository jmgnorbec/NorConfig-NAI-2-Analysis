USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_user]    Script Date: 2026-04-20 10:37:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_user](
	[userid] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_sys_user] PRIMARY KEY CLUSTERED 
(
	[userid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_user] ADD  CONSTRAINT [DF_sys_user_userid]  DEFAULT ('') FOR [userid]
GO

