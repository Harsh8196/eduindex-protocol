import React, { useState, useEffect, createRef } from 'react';
import { useParams } from 'react-router-dom';
import '../css/CreateLesson.css'
import MetaMaskOnboarding from '@metamask/onboarding';
import { create } from 'ipfs-http-client'
import EduxHub from '../script/EduxHub'
import web3 from '../script/web3_'
import { Buffer } from 'buffer';
import { qGetProfile } from '../script/queries';
import { request } from 'graphql-request'

const projectId = process.env.REACT_APP_PROJECTID;
const projectSecret = process.env.REACT_APP_PROJECTSECRET;
const auth = 'Basic ' + Buffer.from(projectId + ':' + projectSecret).toString('base64');
const ipfsClient = create({
    host: 'ipfs.infura.io',
    port: 5001,
    protocol: 'https',
    headers: {
        authorization: auth,
    },
})

function CreateLesson() {
    let { pubid, pubprofileid } = useParams()
    const [errorMessage, setErrorMessage] = useState('')
    const [loading, setLoading] = useState(true)
    const [accounts, setAccounts] = useState('')
    const [lessonname, setLessonname] = useState('')
    const [lessondesc, setLessondesc] = useState('')
    const [actionModule, setActionModule] = useState('')
    const [profileId, setProfileId] = useState(0)
    const [lessonReward, setLessonReward] = useState(0)


    useEffect(() => {
        handleaccounts()
    }, []);

    const handleaccounts = async () => {
        function handleNewAccounts(newAccounts) {
            setAccounts(newAccounts);
        }
        if (MetaMaskOnboarding.isMetaMaskInstalled()) {
            await window.ethereum
                .request({ method: 'eth_requestAccounts' })
                .then(handleNewAccounts);
            await window.ethereum.on('accountsChanged', handleNewAccounts);
            return async () => {
                await window.ethereum.off('accountsChanged', handleNewAccounts);
            };
        }
    }

    useEffect(() => {
        if (accounts.length > 0) {
            getProfile()
        }

    }, [accounts])

    const getProfile = async () => {
        const queryParameters = {
            "to": accounts[0].toString()
        }
        const response = await request(process.env.REACT_APP_GRAPH_URL, qGetProfile, queryParameters)
        if (response.profileCreateds.length > 0) {
            setProfileId(response.profileCreateds[0].profileId)
            return response.profileCreateds[0].profileId
            // //console.log(result)
        } else {
            setProfileId(0)
            return 0
        }
    }

    async function uploadData() {

        try {
            const metaDataPath = await ipfsClient.add(JSON.stringify({
                lessonName: lessonname,
                lessonDesc: lessondesc,
                lessonReward: lessonReward
            }))
            //console.log(metaDataPath)
            await ipfsClient.pin.add(metaDataPath.path.toString())
            return metaDataPath.path.toString()

        } catch (err) {
            //console.log(err)
            setErrorMessage("Opps! Somthing went wrong.")
            return 'error'
        }

    }

    const onSubmitCreateLesson = async (event) => {
        setErrorMessage('')
        event.preventDefault()
        setLoading(false)
        try {
            setErrorMessage('Uploading Lesson data to IPFS...')
            const CID = await uploadData()
            if (CID !== 'error') {
                setErrorMessage('Uploaded Lesson data to IPFS.')
                //console.log(CID)
                let actionModuleInitData = web3.eth.abi.encodeParameters(["uint256"], [lessonReward]);
                //console.log([profileId, CID, pubprofileid, pubid, [actionModule], [actionModuleInitData]])
                let receipt = await EduxHub.methods.lesson([profileId, CID, pubprofileid, pubid, [actionModule], [actionModuleInitData]]).send({
                    from: accounts[0]
                })
                //console.log(receipt)
                setErrorMessage("Lesson created successfully")

            }
            setLoading(true)
            window.location.replace('/mycourse')

        } catch (error) {
            //console.log(error)
            setErrorMessage(error.message)
            setLoading(true)
        }

    }

    return (
        <div className='container-fluid'>
            <div className='row d-flex justify-content-center align-items-center'>
                <div className='CreateLessonContainer'>
                    <h3 className="card-title m-2 text-center">Lesson Portal</h3>
                    <div className="container card shadow rounded-2">
                        <div className="accordion accordion-flush mt-2" id="createFlush">
                            <div className="accordion-item">
                                <h2 className="accordion-header" id="create-heading">
                                    <button className='accordion-button fw-bold rounded-2' type="button" data-bs-toggle="collapse" data-bs-target="#create-collapse" aria-expanded="true" aria-controls="create-collapse">
                                        Create Lesson
                                    </button>
                                </h2>
                                <div id="create-collapse" className='accordion-collapse collapse show' aria-labelledby="create-heading" data-bs-parent="#createFlush">
                                    <div className="accordion-body">
                                        <form onSubmit={onSubmitCreateLesson}>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Creator ProfileId</label>
                                                <div className="col-sm-10">
                                                    <input type='text'
                                                        className="form-control" style={{ background: "#e9ecef" }}
                                                        value={profileId}
                                                        required
                                                        readOnly
                                                    />
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Name</label>
                                                <div className="col-sm-10">
                                                    <input type="text" className='form-control'
                                                        value={lessonname}
                                                        onChange={(event) => setLessonname(event.target.value)}
                                                        required
                                                    />
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Description</label>
                                                <div className="col-sm-10">
                                                    <textarea className="form-control" rows="10"
                                                        value={lessondesc}
                                                        onChange={(event) => setLessondesc(event.target.value)}
                                                        required
                                                    ></textarea>
                                                </div>
                                            </div>
                                            <div className="mb-3 row">
                                                <label className="col-sm-2 col-form-label">Action Module</label>
                                                <div className="col-sm-10">
                                                    <select className="form-select" aria-label="Default select example" required
                                                        onChange={(event) => setActionModule(event.target.value)}>
                                                        <option value=""></option>
                                                        <option value="0xbAFaC84cFdC477C55e2a134f1D7e7873c79394a7">RewardActionModule</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div className="mb-3 row align-items-center">
                                                <label className="col-sm-2 col-form-label">Lesson Reward</label>
                                                <div className="col-sm-2">
                                                    <input type="number" className="form-control"
                                                        value={lessonReward}
                                                        onChange={(event) => setLessonReward(event.target.value)}
                                                        required />
                                                </div>
                                                <div className='col-sm-3'>
                                                    <span className='fw-light'> EDUXPT </span>
                                                </div>
                                            </div>
                                            <span className="text-danger" hidden={!errorMessage}>{errorMessage}</span>
                                            <div className="mb-3 d-flex" style={{ alignItems: 'center' }}>
                                                <button type="submit" className="btn btn-CourseCatalog form-control" disabled={(!loading)}>
                                                    <span className="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true" hidden={loading}></span>
                                                    Create Lesson</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}


export default CreateLesson