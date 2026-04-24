USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_cond_value_list]    Script Date: 2026-04-20 10:27:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_cond_value_list](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sys_condition_UID] [int] NOT NULL,
	[CondValue] [int] NOT NULL,
 CONSTRAINT [sys_cond_value_list_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_cond_value_list]  WITH CHECK ADD  CONSTRAINT [sys_cond_value_list_sys_condition_FK] FOREIGN KEY([sys_condition_UID])
REFERENCES [dbo].[sys_condition] ([UID])
GO

ALTER TABLE [dbo].[sys_cond_value_list] CHECK CONSTRAINT [sys_cond_value_list_sys_condition_FK]
GO

