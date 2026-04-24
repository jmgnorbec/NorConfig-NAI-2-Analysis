USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_condition]    Script Date: 2026-04-20 10:27:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_condition](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sys_limitator_UID] [int] NOT NULL,
	[AndOr] [nvarchar](3) NULL,
	[ConditionTable] [nvarchar](128) NULL,
	[ConditionField] [nvarchar](128) NULL,
	[ConditionType] [int] NULL,
	[ConditionValue] [nvarchar](max) NULL,
 CONSTRAINT [sys_condition_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_condition]  WITH CHECK ADD  CONSTRAINT [sys_condition_sys_condition_type_FK] FOREIGN KEY([ConditionType])
REFERENCES [dbo].[sys_condition_type] ([UID])
GO

ALTER TABLE [dbo].[sys_condition] CHECK CONSTRAINT [sys_condition_sys_condition_type_FK]
GO

ALTER TABLE [dbo].[sys_condition]  WITH CHECK ADD  CONSTRAINT [sys_condition_sys_limitator_FK] FOREIGN KEY([sys_limitator_UID])
REFERENCES [dbo].[sys_limitator] ([UID])
GO

ALTER TABLE [dbo].[sys_condition] CHECK CONSTRAINT [sys_condition_sys_limitator_FK]
GO

