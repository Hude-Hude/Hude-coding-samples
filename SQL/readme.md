# SQL Code for Data Collection, Sampling, and Cleaning   
**Author**: Hude Hude (hh3024@columbia.edu)

## Overview  
This folder contains SQL queries used for data collection, sampling, and cleaning as part of my thesis research on network effects in the PC video game market. The focus of the study is to investigate how the absolute size of a user's social network on Steam influences their game adoption decisions.

### Background  
The dataset for this research, provided by Professor Tudon, includes over 180 million Steam user accounts and captures game libraries, friends, and game-specific information. Given the dataset’s large size (approximately 300GB), I utilized Google Cloud SQL Studio to manage data extraction and cleaning. My goal is to create a representative sample of users and their network connections while minimizing the loss of network structure, an issue that was under-addressed in previous studies.

### Data and Sampling Method  
- **Initial Sampling**: The first step is to randomly sample 10,000 users from the dataset, followed by retrieving their direct and second-degree friends. This process helps retain the network structure while making the dataset manageable for analysis.
- **Network Mapping**: The SQL code constructs various user-friend and indirect-friend relationships, ensuring that we maintain a comprehensive mapping of connections among users.
- **Game Ownership**: The code also integrates game ownership data, mapping each user’s game library and friends' libraries to understand peer effects on game adoption.

The primary challenge addressed by these queries is preserving network integrity during random sampling, ensuring that the relationships between users and their peers are maintained for accurate econometric modeling.

### Key Sections in This Repository:
1. **Random Sampling**: Extract a random sample of 10,000 users and their corresponding friends.
2. **Network Construction**: Build direct and second-degree friend networks.
3. **Game Ownership**: Identify which games each user and their friends own.
4. **Data Cleaning**: Remove users and games with no ownership data to optimize the dataset for analysis.
5. **Network Effect Analysis**: Prepare data for regression models to examine how the size of a user's network impacts game adoption.
