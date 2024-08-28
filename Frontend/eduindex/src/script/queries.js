import { gql } from 'graphql-request'

export const qGetProfile = gql`
    query getProfile($to: String) {
        profileCreateds(where: { to: $to }) {
            profileId
            to
        }
    }
`;

export const gGetProfileMetadata = gql`
query getProfileData($profileId: BigInt) {
  profileMetadataSets(where: { profileId: $profileId}) {
    metadata
  }
}
`;

export const qGetAllCourse = gql`
query getAllCourse {
  courseCreateds {
    pubId
    courseParams_profileId
    courseParams_contentURI
    courseParams_certificateModule
    courseParams_collectModule
    courseParams_collectModulesInitData
    timestampParam
    transactionExecutor
  }
}
`;

export const qGetCourseByProfile = gql`
query getCourseByProfile($profileId: BigInt) {
  courseCreateds(where: { courseParams_profileId: $profileId }) {
    pubId
    courseParams_profileId
    courseParams_contentURI
    courseParams_certificateModule
    courseParams_collectModule
    courseParams_collectModulesInitData
    timestampParam
    transactionExecutor
  }
}
`;

export const qGetCourseByPublication = gql`
query getCourseByPublication($publicationId: BigInt) {
  courseCreateds(where: { pubId: $publicationId }) {
    pubId
    courseParams_profileId
    courseParams_contentURI
    courseParams_certificateModule
    courseParams_collectModule
    courseParams_collectModulesInitData
    timestampParam
    transactionExecutor
  }
}
`;

export const qGetCourseCollectData = gql`
query getCourseCollectData($publicationId: BigInt) {
  collecteds(
    where: { publicationCollectParams_publicationCollectedProfileId: $publicationId }) {
    collectModuleReturnData
    transactionExecutor
    timestampParam
    publicationCollectParams_publicationCollectedProfileId
    publicationCollectParams_publicationCollectedId
    publicationCollectParams_currency
    publicationCollectParams_collectorProfileId
    publicationCollectParams_collectModuleData
    publicationCollectParams_collectModuleAddress
  }
}
`;

export const qGetCourseCollectedByProfile = gql`
query getCourseCollectedByProfile($profileId: BigInt) {
  collecteds(where: { publicationCollectParams_collectorProfileId: $profileId }) {
    collectModuleReturnData
    transactionExecutor
    timestampParam
    publicationCollectParams_publicationCollectedProfileId
    publicationCollectParams_publicationCollectedId
    publicationCollectParams_currency
    publicationCollectParams_collectorProfileId
    publicationCollectParams_collectModuleData
    publicationCollectParams_collectModuleAddress
  }
}
`;

export const qGetCourseCollectedByProfilePubId = gql`
query getCourseCollectedByProfilePubId($profileId: BigInt, $publicationId: BigInt) {
  collecteds(
    where: {
      publicationCollectParams_collectorProfileId: $profileId
      publicationCollectParams_publicationCollectedId: $publicationId
    }
  ) {
    collectModuleReturnData
    transactionExecutor
    timestampParam
    publicationCollectParams_publicationCollectedProfileId
    publicationCollectParams_publicationCollectedId
    publicationCollectParams_currency
    publicationCollectParams_collectorProfileId
    publicationCollectParams_collectModuleData
    publicationCollectParams_collectModuleAddress
  }
}
`;

export const qGetCompletedLesson = gql`
query getCompletedLesson($pointedpublicationId: [BigInt!]) {
  progressCreateds(
    where: { progressParams_pointedPubId_in: $pointedpublicationId }
  ) {
    progressParams_metadataURI
    progressParams_pointedProfileId
    progressParams_pointedPubId
    progressParams_profileId
    pubId
    timestamp_
    transactionExecutor
  }
}
`;

export const qGetAllLessonForCourse = gql`
query getAllLessonForCourse($pointedPubId: BigInt) {
  lessonCreateds(orderBy: timestampParam, orderDirection: asc, where: { lessonParams_pointedPubId: $pointedPubId }) {
    lessonParams_actionModules
    lessonParams_actionModulesInitDatas
    lessonParams_contentURI
    lessonParams_pointedProfileId
    lessonParams_pointedPubId
    lessonParams_profileId
    pubId
    transactionExecutor
    timestampParam
  }
}
`;